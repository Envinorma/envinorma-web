import { buildUrlFromCheckedArretes } from 'components/create_url_from_checked_arretes';

test('appends ? to baseUrl when no arretes are present', () => {
  console.log(buildUrlFromCheckedArretes);
  expect(buildUrlFromCheckedArretes('example.com', [], [])).toBe('example.com?');
});

test('concatenates am_id to baseUrl when one ams are present', () => {
  expect(buildUrlFromCheckedArretes('example.com', [0], [])).toBe('example.com?am_ids[]=0');
});

test('concatenates am_ids to baseUrl when 2 aps are present', () => {
  expect(buildUrlFromCheckedArretes('example.com', [0, 1], [])).toBe('example.com?am_ids[]=0&am_ids[]=1');
});

test('concatenates ap_ids to baseUrl when 2 ams are present', () => {
  expect(buildUrlFromCheckedArretes('example.com', [], [0, 1])).toBe('example.com?ap_ids[]=0&ap_ids[]=1');
});

test('concatenates am_ids then ap_ids to baseUrl when both arretes types are present', () => {
  expect(buildUrlFromCheckedArretes('example.com', [2], [0, 1])).toBe('example.com?am_ids[]=2&ap_ids[]=0&ap_ids[]=1');
});
